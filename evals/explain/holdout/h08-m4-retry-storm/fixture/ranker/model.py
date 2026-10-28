from pydantic import BaseModel

from ranker.index import candidates, features
from ranker.weights import WEIGHTS


class RankRequest(BaseModel):
    query: str
    limit: int = 20


def score(request: RankRequest):
    scored = []
    for document in candidates(request.query):
        value = sum(WEIGHTS[name] * feature for name, feature in features(request.query, document).items())
        scored.append((value, document.id))
    scored.sort(reverse=True)
    return [document_id for _, document_id in scored[: request.limit]]
