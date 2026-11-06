package routes

import "net/http"

func GetOrgAddOns(w http.ResponseWriter, r *http.Request, orgID string) {
	user := sessionUser(r)
	if user == nil {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	if !isMember(user, orgID) {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}
	writeJSON(w, listAddOns(orgID))
}

func SetFeatureFlag(w http.ResponseWriter, r *http.Request, orgID string) {
	user := sessionUser(r)
	if !isSuperAdmin(user) {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}
	if isMinistryOrg(orgID) {
		http.Error(w, "feature locked for this organisation", http.StatusForbidden)
		return
	}
	applyFlag(orgID, r)
	w.WriteHeader(http.StatusOK)
}
