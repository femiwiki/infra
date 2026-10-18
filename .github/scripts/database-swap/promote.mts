// With ProxySQL on, holds the writes, promotes the replica, and moves the
// primary's interface and backups to it
import {
	type Args,
	ASG,
	admin,
	aws,
	caughtUp,
	iface,
	shell,
	slaveStatus,
	sql,
	tag,
	until,
} from "./hosts.mts";

const REPLICA_CNF = "/etc/my.cnf.d/zz-femiwiki-replica.cnf";

export const promote = async ({ core, env }: Args) => {
	const { PRIMARY: primary = "", REPLICA: id = "" } = env;
	const address = env.REPLICA_ADDRESS ?? "";
	const eni = iface();
	const fixed: string = eni.PrivateIpAddress;
	if (eni.Attachment.InstanceId !== primary)
		throw new Error(
			`the interface moved to ${eni.Attachment.InstanceId} since the replica was launched`,
		);
	if (!caughtUp(await slaveStatus(id)))
		throw new Error(`${id} is no longer caught up`);

	// From here until the replica is writable, the wiki's queries wait in ProxySQL
	const servers = (change: string) =>
		admin(`${change}; LOAD MYSQL SERVERS TO RUNTIME;`);
	servers(
		`UPDATE mysql_servers SET status = 'OFFLINE_SOFT' WHERE hostname = '${fixed}'`,
	);
	try {
		await until("the transactions in flight to finish", 0.25, 1, () =>
			admin(
				`SELECT COALESCE(SUM(ConnUsed), 0) FROM stats_mysql_connection_pool WHERE srv_host = '${fixed}'`,
			) === "0"
				? true
				: undefined,
		);
		const gtid = await sql(
			primary,
			"SET GLOBAL read_only = ON; SELECT @@gtid_binlog_pos",
		);
		const waited = await sql(id, `SELECT MASTER_GTID_WAIT('${gtid}', 10)`);
		if (waited !== "0") throw new Error(`${id} did not reach ${gtid}`);
	} catch (e) {
		await sql(primary, "SET GLOBAL read_only = OFF");
		servers(
			`UPDATE mysql_servers SET status = 'ONLINE' WHERE hostname = '${fixed}'`,
		);
		throw e;
	}

	// No way back past here: the replica takes the writes
	await shell(
		id,
		`rm -f ${REPLICA_CNF} && mysql -uroot -e 'STOP SLAVE; RESET SLAVE ALL; SET GLOBAL read_only = OFF;'`,
	);
	servers(
		`INSERT INTO mysql_servers (hostgroup_id, hostname, port) VALUES (0, '${address}', 3306); DELETE FROM mysql_servers WHERE hostname = '${fixed}'`,
	);
	core.info(`${id} is the primary; ProxySQL sends the wiki to ${address}`);

	aws`ec2 detach-network-interface --attachment-id ${eni.Attachment.AttachmentId}`;
	await until("the interface to come loose", 5, 5, () =>
		iface().Status === "available" ? true : undefined,
	);
	aws`ec2 attach-network-interface --network-interface-id ${eni.NetworkInterfaceId} --instance-id ${id} --device-index 1`;
	await until(`${id} to answer at ${fixed}`, 5, 10, async () =>
		(await shell(id, `ip -4 -o addr show | grep -F ' ${fixed}/' || true`))
			? true
			: undefined,
	);

	tag(id, { MysqlBackup: "true", Swap: "primary" });
	tag(primary, { MysqlBackup: "false", Swap: "retired" });
	await shell(
		primary,
		"systemctl disable --now mysql-backup.timer 2>/dev/null || true",
	);
	aws`autoscaling set-instance-protection --auto-scaling-group-name ${ASG} --instance-ids ${id} --protected-from-scale-in`;
	core.info(`${fixed} now reaches ${id}`);
};
