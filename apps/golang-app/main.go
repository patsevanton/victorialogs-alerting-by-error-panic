package main

import (
	"log"
	"net/http"
	"os"
)

var (
	// infoLog пишет обычные сообщения (старт сервиса, health и т.п.) в stdout —
	// их собирает Vector как штатный поток логов приложения.
	infoLog = log.New(os.Stdout, "", log.LstdFlags)

	// errLog пишет panic / fatal / error в stderr. Это не косметика, а
	// обязательное соглашение: Kubernetes-рантайм пишет stdout и stderr в
	// отдельные .log-файлы, а Vector размечает каждую строку полем
	// stream=stdout|stderr. Благодаря этому в правилах VMRule ошибки можно
	// выбрать дешёвым фильтром stream:=stderr и только потом матчить текст
	// регуляркой (_msg:~"panic:"), не гоняя regex по всему потоку stdout.
	// Если писать ошибки в stdout, придётся ловить их исключительно по
	// тексту — это самый дорогой сценарий для VictoriaLogs.
	errLog = log.New(os.Stderr, "", log.LstdFlags)
)

// Приложение с набором эндпоинтов, каждый из которых воспроизводит
// реальный класс ошибок в проде. Обычные логи уходят в stdout,
// ошибки (panic / fatal / error) — обязательно в stderr. Vector собирает
// оба потока и отправляет их в VictoriaLogs, где строки размечены полем
// stream=stdout|stderr.
func main() {
	mux := http.NewServeMux()

	// panic("...") — обрабатывается в defer/recover, но в stderr попадает
	// стек и сообщение через errLog.Printf.
	mux.HandleFunc("/panic", func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if rec := recover(); rec != nil {
				errLog.Printf("ERROR: recovered panic on /panic: %v", rec)
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
	// Сообщение уходит в stderr (через errLog.Fatal), обычный infoLog не трогается.
	mux.HandleFunc("/fatal", func(w http.ResponseWriter, r *http.Request) {
		errLog.Fatalf("FATAL: unrecoverable configuration error on /fatal")
	})

	// Логируемая ошибка без падения — ERROR в stderr, ответ 502 клиенту.
	mux.HandleFunc("/error", func(w http.ResponseWriter, r *http.Request) {
		errLog.Printf("ERROR: failed to connect to upstream on /error")
		http.Error(w, "upstream failure", http.StatusBadGateway)
	})

	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok\n"))
	})

	srv := &http.Server{Addr: ":8080", Handler: mux}
	infoLog.Printf("crash-app listening on :8080")
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		errLog.Printf("FATAL: %v", err)
		os.Exit(1)
	}
}
