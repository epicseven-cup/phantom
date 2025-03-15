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

type Message struct {
	Content string `json:"content"`
}

type IncomingMessage struct {
	RequestPost int `json:"request_post"`
}

func streamPostIt(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)

	if err != nil {
		log.Print("Upgrade: ", err)
	}

	defer c.Close()

	for {
		msg := IncomingMessage{}
		err := c.ReadJSON(&msg)
		if err != nil {
			log.Print("Error when reading: ", err)
		}

		log.Print("Message: : ", msg)

		if msg.RequestPost > 0 {
			for range msg.RequestPost {
				data := Message{Content: "Hello world"}

				err = c.WriteJSON(data)
				if err != nil {
					log.Print(err)
					return
				}

			}
		}

	}
}

func main() {
	http.HandleFunc("/postit", streamPostIt)
	err := http.ListenAndServe("localhost:3001", nil)
	if err != nil {
		return
	}
}
