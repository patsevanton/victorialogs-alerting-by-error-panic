package main

import (
	"log"
	"net/http"
	"os"
)

// Приложение с набором эндпоинтов, каждый из которых воспроизводит
// реальный класс ошибок в проде. Все сообщения пишутся в stdout —
// vlagent собирает их и отправляет в VictoriaLogs.
func main() {
	mux := http.NewServeMux()

	// panic("...") — обрабатывается в defer/recover, но в лог попадает
	// стек и сообщение через log.Printf.
	mux.HandleFunc("/panic", func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if rec := recover(); rec != nil {
				log.Printf("ERROR: recovered panic on /panic: %v", rec)
				http.Error(w, "internal failure", http.StatusInternalServerError)
			}
		}()
		panic("boom: something went really wrong")
	})

	// nil pointer dereference — runtime-паника. Пример без recover:
	// pod падает, лог со стеком уходит в VictoriaLogs до смерти контейнера.
	mux.HandleFunc("/nil", func(w http.ResponseWriter, r *http.Request) {
		var p *int
		_ = *p //nolint
	})

	// index out of range — runtime-паника.
	mux.HandleFunc("/index", func(w http.ResponseWriter, r *http.Request) {
		arr := []int{1, 2, 3}
		_ = arr[10] //nolint
	})

	// log.Fatal — пишет сообщение и завершает процесс (os.Exit(1)).
	mux.HandleFunc("/fatal", func(w http.ResponseWriter, r *http.Request) {
		log.Fatalf("FATAL: unrecoverable configuration error on /fatal")
	})

	// Логируемая ошибка без падения — просто ERROR в логе.
	mux.HandleFunc("/error", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("ERROR: failed to connect to upstream on /error")
		http.Error(w, "upstream failure", http.StatusBadGateway)
	})

	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok\n"))
	})

	srv := &http.Server{Addr: ":8080", Handler: mux}
	log.Printf("crash-app listening on :8080")
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Printf("FATAL: %v", err)
		os.Exit(1)
	}
}
