#!/usr/bin/env bun

import { resolve4 } from "dns/promises";
import { readFile } from "fs/promises";
import { homedir } from "os";
import { join } from "path";

const domain = process.argv[2];

const addresses = await resolve4(domain);

const sshConfigPath = join(homedir(), ".ssh", "config");
const configContent = await readFile(sshConfigPath, "utf8");

const lines = configContent.split("\n");
const sshHosts = [];
let currentHost = null;

for (const line of lines) {
	const hostMatch = line.match(/^Host\s+(.*)$/);
	const hostNameMatch = line.match(/^HostName\s+(.*)$/);

	if (hostMatch) {
		currentHost = hostMatch[1];
	} else if (hostNameMatch && currentHost) {
		sshHosts.push({
			host: currentHost,
			hostname: hostNameMatch[1],
		});
		currentHost = null;
	}
}

const matchingHosts = sshHosts
	.filter((sshHost) => addresses.includes(sshHost.hostname))
	.map((sshHost) => sshHost.host)
	.join(" ");

console.log(matchingHosts);
