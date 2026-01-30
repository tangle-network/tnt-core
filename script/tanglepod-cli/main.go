package main

import (
	"fmt"
	"os"

	"github.com/tangle-network/tnt-core/script/tanglepod-cli/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
