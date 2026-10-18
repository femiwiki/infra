// With ProxySQL off again, lets the group end the old primary if it is one of its own
import { type Args, ASG, aws, group, members } from "./hosts.mts";

export const retire = async ({ core, env }: Args) => {
	const { PRIMARY: primary = "" } = env;
	if (!members().includes(primary)) {
		core.notice(
			`${primary} is outside the ${ASG} group, so it is left running for the code to remove`,
		);
		return;
	}
	aws`autoscaling set-instance-protection --auto-scaling-group-name ${ASG} --instance-ids ${primary} --no-protected-from-scale-in`;
	aws`autoscaling set-desired-capacity --auto-scaling-group-name ${ASG} --desired-capacity ${group().DesiredCapacity - 1}`;
	core.info(`The group ends ${primary}`);
};
