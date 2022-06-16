/*
 * Copyright (c) 2022-present unTill Pro, Ltd.
 * @author Maxim Geraskin
 */

package ce

func Provide(cfg Config) (impl IServer, cleanup func(), err error) {
	return &ce{cfg: cfg}, func() {}, nil
}
