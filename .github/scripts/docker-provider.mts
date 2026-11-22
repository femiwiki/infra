// Puts the fork the lock file pins into terraform.d/plugins/, the implied local
// mirror tofu init reads; the fork is on no registry (femiwiki/femiwiki#577)
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import type { Args } from "./database-swap/hosts.mts";

const SOURCE = "femiwiki.invalid/femiwiki/docker";
const REPO = "femiwiki/terraform-provider-docker-per-resource-host";

export const install = async ({ core, env }: Args) => {
	const root = env.ROOT ?? "";
	const lock = readFileSync(`${root}/.terraform.lock.hcl`, "utf8");
	const version = lock.match(
		new RegExp(`provider "${SOURCE}" \\{\\s*version\\s*=\\s*"([^"]+)"`),
	)?.[1];
	if (!version) {
		core.setFailed(`${root}/.terraform.lock.hcl pins no ${SOURCE}`);
		return;
	}
	const arch = { x64: "amd64", arm64: "arm64" }[process.arch as string];
	if (!arch) {
		core.setFailed(`${REPO} has no build for ${process.arch}`);
		return;
	}
	const name = `terraform-provider-docker_${version}_linux_${arch}.zip`;
	const url = `https://github.com/${REPO}/releases/download/v${version}/${name}`;
	const response = await fetch(url);
	if (!response.ok) {
		core.setFailed(`${url} answered ${response.status}`);
		return;
	}
	const dir = `${root}/terraform.d/plugins/${SOURCE}`;
	mkdirSync(dir, { recursive: true });
	writeFileSync(`${dir}/${name}`, Buffer.from(await response.arrayBuffer()));
	core.info(`${name} is in ${dir}`);
};
