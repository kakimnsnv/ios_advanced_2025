package service

import (
	"github.com/kakimnsnv/ios_final_back/internal/repository"
	"go.uber.org/zap"
)

type ReviewService interface{}

type reviewSvc struct {
	log  *zap.Logger
	repo repository.ReviewRepo
}

func NewReviewService(log *zap.Logger, repo repository.ReviewRepo) ReviewService {
	return &reviewSvc{
		log:  log,
		repo: repo,
	}
}
