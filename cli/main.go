/*
 * Copyright (c) 2022-present unTill Pro, Ltd.
 * @author Maxim Geraskin
 */

package main

import (
	_ "embed"
	"flag"
	"fmt"
	"os"
	"path/filepath"

	"github.com/heeus/ce"
)

func init() {

	flag.Usage = func() {
		w := flag.CommandLine.Output() // may be os.Stderr - but not necessarily
		fmt.Fprintf(w, "Usage:\n")
		fmt.Fprintln(w)
		fmt.Fprintf(w, "\t%s [options] <command>\n", filepath.Base(os.Args[0]))
		fmt.Fprintln(w)
		fmt.Fprintf(w, "Commands:\n")
		fmt.Fprintln(w)
		fmt.Fprintf(w, "\thelp\t\tprint help\n")
		fmt.Fprintf(w, "\tserver\t\tstart Server\n")
		fmt.Fprintf(w, "\tversion\t\tprint version\n")
		fmt.Fprintln(w)
		fmt.Fprintf(w, "Options:\n")
		fmt.Fprintln(w)
		flag.PrintDefaults()
	}
}

func main() {

	var cfg ce.Config

	flag.IntVar(&cfg.AdminPort, "aport", ce.DefaultAdminPort, "admin port, will be used for 127.0.0.1 only")
	flag.Parse()

	if flag.Arg(0) == "version" {
		fmt.Println(ce.Version)
		return
	}
	if flag.Arg(0) == "server" {
		ce, cleanup, err := ce.Provide(cfg)
		if err != nil {
			fmt.Println(err)
			return
		}
		defer cleanup()
		_ = ce.Run()
		return
	}
	flag.Usage()
}
