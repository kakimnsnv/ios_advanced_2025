package service

import (
	"github.com/kakimnsnv/ios_final_back/internal/repository"
	"go.uber.org/zap"
)

type MovieService interface{}

type movieSvc struct {
	log  *zap.Logger
	repo repository.MovieRepo
}

func NewMovieService(log *zap.Logger, repo repository.MovieRepo) MovieService {
	return &movieSvc{
		log:  log,
		repo: repo,
	}
}
