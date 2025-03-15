package main

import (
	"github.com/gorilla/websocket"
	"log"
	"net/http"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func streamPostIt(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)

	if err != nil {
		log.Print("Upgrade: ", err)
	}

	defer c.Close()

	for {
		mt, message, err := c.ReadMessage()
		if err != nil {
			log.Print("Error when reading: ", err)
		}

		log.Print("Mesasge Type: ", mt)
		log.Print("Mesasge: : ", message)

	}
}

func main() {
	http.HandleFunc("/postit", streamPostIt)
	err := http.ListenAndServe("localhost:3001", nil)
	if err != nil {
		return
	}
}
