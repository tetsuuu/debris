package main

import (
	"github.com/tetsuuu/debris/simple-server/handler"
	"github.com/tetsuuu/debris/simple-server/util"
	"net/http"
)

func main() {
	logger.Init()

	http.HandleFunc("/", handler.HelloHandler)
	http.HandleFunc("/health", handler.HealthHandler)

	logger.Info("Server listening on port 8080...")
	http.ListenAndServe(":8080", nil)
}
