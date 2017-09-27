package main

import (
	"bufio"
	"os"
	"fmt"
	"syscall"
	"strings"
)

func main() {
	for (true) {
		reader := bufio.NewReader(os.Stdin)
		fmt.Print("Enter cmd: ")
		input, _ := reader.ReadString('\n')

		parsedInput := strings.Split(strings.TrimSpace(input), " ")

		runCmd(parsedInput[0], parsedInput)
	}
}

func runCmd(cmd string, args []string) {
	workingDirectory, err := os.Getwd()
	if err != nil {
		println("Error Getwd")
		panic(err)
	}

	sysProcAttr := syscall.SysProcAttr{}

	files := make([]uintptr, 3)
	files[0] = os.Stdin.Fd()
	files[1] = os.Stdout.Fd()
	files[2] = os.Stderr.Fd()
	procAttr := syscall.ProcAttr{Dir: workingDirectory, Env: os.Environ(), Files: files, Sys: &sysProcAttr}

	pid, err := syscall.ForkExec(cmd, args, &procAttr)

	if err != nil {
		println("Error ForkExec: " + cmd)
		panic(err)
	}

	var ws syscall.WaitStatus
	_, err = syscall.Wait4(pid, &ws, syscall.WUNTRACED, nil)

	inCh := make(chan string)
	close(inCh)

	if err != nil {
		println("Error Wait4: " + cmd)
		panic(err)
	}
}
