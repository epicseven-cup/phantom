package main

import (
	"context"
	"encoding/json"
	"github.com/gorilla/websocket"
	"github.com/jackc/pgx/v5/pgxpool"
	"log"
	"net/http"
	"os"
	"strings"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

var conn *pgxpool.Pool

//var connCollection []*websocket.Conn = []*websocket.Conn{}

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
	//connCollection = append(connCollection, c)

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

				content = strings.Replace(content, "<", "&lt;", -1)
				content = strings.Replace(content, ">", "&gt;", -1)
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
}

func createPost(w http.ResponseWriter, r *http.Request) {
	msg := Message{}
	body := r.Body

	decoder := json.NewDecoder(body)
	err := decoder.Decode(&msg)

	content := strings.Replace(msg.Content, "&", "&amp;", -1)
	content = strings.Replace(content, "<", "&lt;", -1)
	content = strings.Replace(content, ">", "&gt;", -1)
	if err != nil {
		return
	}

	rows, err := conn.Query(context.Background(), "INSERT INTO posts (content) VALUES ($1)", content)
	if err != nil {
		log.Fatalln(err)
		return
	}
	defer rows.Close()

	// Need to put the broadcast feature on hold for now, I need to restructure this backend a bit.
	// My rushing the backend is making more issue
	//for i := range connCollection {
	//	c := connCollection[i]
	//	request := IncomingMessage{RequestPost: 1}
	//	err = c.WriteJSON(request)
	//	if err != nil {
	//		log.Fatalln(err)
	//		return
	//	}
	//}

	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.WriteHeader(http.StatusCreated)
}

func main() {
	//conn, err := pgx.Connect(context.Background(), "postgres://postgres:example@localhost:5432/postgres")
	//if err != nil {
	//	log.Fatalln(err)
	//}
	conn, _ = pgxpool.New(context.Background(), os.Getenv("POSTGRES_URI"))
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
	err = http.ListenAndServe("0.0.0.0:3001", nil)
	if err != nil {
		log.Fatalln(err)
		return
	}
}
