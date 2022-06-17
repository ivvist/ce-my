/*
 * Copyright (c) 2022-present unTill Pro, Ltd.
 * @author Maxim Geraskin
 */

package ce

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"sync"
	"time"
)

type ce struct {
	cfg Config
	wg  sync.WaitGroup
}

var signals chan os.Signal

func (ce *ce) Run() error {

	ctx, cancel := context.WithCancel(context.Background())

	signals = make(chan os.Signal, 1)
	signal.Notify(signals, os.Interrupt)

	ctx = ce.start(ctx)

	sig := <-signals
	fmt.Println(sig)
	cancel()
	return ce.join(ctx)
}

func (ce *ce) start(ctx context.Context) (newCtx context.Context) {
	ce.wg.Add(1)
	go ce.run(ctx)
	return ctx
}

func (ce *ce) run(ctx context.Context) {
	defer ce.wg.Done()
	for ctx.Err() == nil {
		time.Sleep(1 * time.Second)
	}
}

func (ce *ce) join(_ context.Context) (err error) {
	ce.wg.Wait()
	return nil
}
