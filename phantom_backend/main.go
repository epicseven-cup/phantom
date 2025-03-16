package main

import (
	"context"
	"encoding/json"
	"github.com/gorilla/websocket"
	"github.com/jackc/pgx/v5/pgxpool"
	"log"
	"net/http"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

var conn *pgxpool.Pool

type Message struct {
	Content string `json:"content"`
}

type IncomingMessage struct {
	RequestPost int `json:"request_post"`
}

func streamPostIt(w http.ResponseWriter, r *http.Request) {

	//go func() {
	c, err := upgrader.Upgrade(w, r, nil)

	if err != nil {
		log.Print("Upgrade: ", err)
		return
	}

	defer c.Close()

	seen := map[int]bool{0: true} // id as key
	for {
		msg := IncomingMessage{}
		err := c.ReadJSON(&msg)
		if err != nil {
			log.Print("Error when reading: ", err)
			return
		}

		log.Print("Message: : ", msg)

		if msg.RequestPost > 0 {
			var keys []int
			for k := range seen {
				keys = append(keys, k)
			}
			rows, err := conn.Query(context.Background(), "SELECT id, content FROM posts WHERE NOT (id = ANY ($1) ) LIMIT ($2)", keys, msg.RequestPost)
			if err != nil {
				log.Fatalln(err)
				return
			}

			for rows.Next() {
				var id int
				var content string
				err := rows.Scan(&id, &content)
				log.Println(id)

				if err != nil {
					log.Fatalln(err)
					return
				}
				_, ok := seen[id]
				if !ok {

					data := Message{Content: content}
					err = c.WriteJSON(data)
					if err != nil {
						log.Print(err)
						return
					}

					seen[id] = true
				}
			}
			rows.Close()
		}

	}
	//}
}

func createPost(w http.ResponseWriter, r *http.Request) {
	msg := Message{}
	body := r.Body
	//if err != nil {
	//	log.Fatalln(err)
	//	return
	//}
	decoder := json.NewDecoder(body)
	err := decoder.Decode(&msg)
	if err != nil {
		return
	}

	rows, err := conn.Query(context.Background(), "INSERT INTO posts (content) VALUES ($1)", msg.Content)
	if err != nil {
		log.Fatalln(err)
		return
	}
	defer rows.Close()
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.WriteHeader(http.StatusCreated)
}

func main() {
	//conn, err := pgx.Connect(context.Background(), "postgres://postgres:example@localhost:5432/postgres")
	//if err != nil {
	//	log.Fatalln(err)
	//}
	conn, _ = pgxpool.New(context.Background(), "postgres://postgres:example@localhost:5432/postgres")
	err := conn.Ping(context.Background())
	if err != nil {
		log.Fatalln(err)
		return
	}

	_, err = conn.Query(context.Background(), "CREATE TABLE posts (id SERIAL, content TEXT NOT NULL)")
	if err != nil {
		log.Fatalln(err)
		return
	}

	err = conn.Ping(context.Background())
	if err != nil {
		log.Fatalln(err)
		return
	}
	http.HandleFunc("/postit", streamPostIt)
	http.HandleFunc("/create", createPost)
	err = http.ListenAndServe("localhost:3001", nil)
	if err != nil {
		log.Fatalln(err)
		return
	}
}
