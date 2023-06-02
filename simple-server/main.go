package main

import (
	// "github.com/tetsuuu/debris/simple-server/handler"
	"log"
	"net/http"
	"os"
)

var logger *log.Logger

func init() {
	logFile, err := os.OpenFile("server.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err != nil {
		log.Fatal("Failed opening log file:", err)
	}

	logger = log.New(logFile, "", log.LstdFlags|log.Lmicroseconds)
}

func main() {
	logger.Println("Start service")

	// http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
	// 	hello.HelloHandler(w, r, logger)
	// })

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		logger.Println("Failed starting service:", err)
	}
}
