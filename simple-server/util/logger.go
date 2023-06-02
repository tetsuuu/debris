package logger

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"
)

type LogEntry struct {
	Timestamp string `json:"timestamp"`
	Level     string `json:"level"`
	Message   string `json:"message"`
}

var (
	infoLogger  *log.Logger
	errorLogger *log.Logger
)

func Init() {
	infoLogger = log.New(os.Stdout, "", 0)
	errorLogger = log.New(os.Stderr, "", 0)
}

func Info(message string) {
	logEntry := LogEntry{
		Timestamp: time.Now().Format(time.RFC3339),
		Level:     "INFO",
		Message:   message,
	}

	logJSON, err := json.Marshal(logEntry)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error marshaling log entry: %v\n", err)
		return
	}

	infoLogger.Println(string(logJSON))
}

func Error(message string) {
	logEntry := LogEntry{
		Timestamp: time.Now().Format(time.RFC3339),
		Level:     "ERROR",
		Message:   message,
	}

	logJSON, err := json.Marshal(logEntry)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error marshaling log entry: %v\n", err)
		return
	}

	errorLogger.Println(string(logJSON))
}
