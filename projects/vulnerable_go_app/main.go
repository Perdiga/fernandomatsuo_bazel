package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"

	_ "github.com/lib/pq"
)

func main() {
	// Set up the database connection (adjust DSN as needed)
	db, err := sql.Open("postgres", "user=youruser password=yourpassword dbname=yourdb sslmode=disable")
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// HTTP handler with a SQL injection vulnerability
	http.HandleFunc("/user", func(w http.ResponseWriter, r *http.Request) {
		// Get the username from query parameters
		username := r.URL.Query().Get("username")
		if username == "" {
			http.Error(w, "Missing username", http.StatusBadRequest)
			return
		}

		// Vulnerable query (SQL Injection)
		query := fmt.Sprintf("SELECT id, name FROM users WHERE name = '%s'", username)
		rows, err := db.Query(query)
		if err != nil {
			http.Error(w, "Database error", http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		// Fetch and display results
		for rows.Next() {
			var id int
			var name string
			if err := rows.Scan(&id, &name); err != nil {
				http.Error(w, "Error scanning row", http.StatusInternalServerError)
				return
			}
			fmt.Fprintf(w, "User: ID=%d, Name=%s\n", id, name)
		}
	})

	// Start the HTTP server
	fmt.Println("Server running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
