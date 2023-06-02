package hello

import (
	"encoding/json"
	"log"
	"net/http"
)

type Message struct {
	Text string `json:"text"`
}

func HelloHandler(w http.ResponseWriter, r *http.Request, logger *log.Logger) {
	message := Message{Text: "Hello, World!"}

	logger.Printf("Recieve request: %s %s", r.Method, r.URL.Path)

	logMessage, err := json.Marshal(message)
	if err != nil {
		logger.Println("Failed encording logs:", err)
	} else {
		logger.Println(string(logMessage))
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	err = json.NewEncoder(w).Encode(message)
	if err != nil {
		logger.Println("Failed logging response:", err)
	}
}
