package main

import (
    "fmt"
    "net/http"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello, World!")
}

func main() {
    http.HandleFunc("/", helloHandler)
    fmt.Println("Starting server on :80")
    if err := http.ListenAndServe("0.0.0.0:80", nil); err != nil {
        fmt.Println("Error starting server:", err)
    }
}
