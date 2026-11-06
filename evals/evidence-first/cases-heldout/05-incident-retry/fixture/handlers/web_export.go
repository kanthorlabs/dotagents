package handlers

import "net/http"

func WebExportHandler(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	if err := auth.Require(ctx); err != nil {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	serveExport(w, r)
}
