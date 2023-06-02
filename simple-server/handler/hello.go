package handler

import (
	"github.com/tetsuuu/debris/simple-server/util"
	"net/http"
)

func HelloHandler(w http.ResponseWriter, r *http.Request) {
	logger.Info("Hello, World!")
}
