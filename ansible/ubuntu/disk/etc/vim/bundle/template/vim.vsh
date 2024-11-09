#!/usr/bin/env -S v run

fn sh(cmd string){
	println("❯ $cmd")
	print(execute_or_exit(cmd).output)
}

chdir(dir(executable()))?

