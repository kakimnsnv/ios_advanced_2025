package service

import (
	"errors"

	"github.com/kakimnsnv/ios_final_back/internal/models"
	"github.com/kakimnsnv/ios_final_back/internal/repository"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.uber.org/zap"
)

type MovieService interface {
	ListMovies() ([]*models.Movie, error)
	GetMovie(id *primitive.ObjectID) (*models.Movie, error)
	CreateMovie(actorID *primitive.ObjectID, movie *models.CreateMovieRequest) (*primitive.ObjectID, error)
	UpdateMovie(actorID *primitive.ObjectID, id *primitive.ObjectID, movie *models.UpdateMovieRequest) (*models.Movie, error)
	DeleteMovie(actorID *primitive.ObjectID, id *primitive.ObjectID) error
}

type movieSvc struct {
	log      *zap.Logger
	repo     repository.MovieRepo
	userRepo repository.UserRepo
}

func NewMovieService(log *zap.Logger, repo repository.MovieRepo, userRepo repository.UserRepo) MovieService {
	return &movieSvc{
		log:      log,
		repo:     repo,
		userRepo: userRepo,
	}
}

func (s *movieSvc) ListMovies() ([]*models.Movie, error) {
	movies, err := s.repo.ListMovies()
	if err != nil {
		return nil, err
	}
	return movies, nil
}

func (s *movieSvc) GetMovie(id *primitive.ObjectID) (*models.Movie, error) {
	movie, err := s.repo.GetMovie(id)
	if err != nil {
		return nil, err
	}
	return movie, nil
}

func (s *movieSvc) CreateMovie(actorID *primitive.ObjectID, movie *models.CreateMovieRequest) (*primitive.ObjectID, error) {
	actor, err := s.userRepo.GetUserByID(actorID)
	if err != nil {
		return nil, err
	}

	if !HasPermission(actor, ResourceMovie, ActionCreate, nil) {
		return nil, errors.New("unauthorized")
	}

	return s.repo.CreateMovie(movie)
}

func (s *movieSvc) UpdateMovie(actorID *primitive.ObjectID, id *primitive.ObjectID, movie *models.UpdateMovieRequest) (*models.Movie, error) {
	actor, err := s.userRepo.GetUserByID(actorID)
	if err != nil {
		return nil, err
	}

	if !HasPermission(actor, ResourceMovie, ActionUpdate, nil) {
		return nil, errors.New("unauthorized")
	}

	return s.repo.UpdateMovie(id, movie)
}

func (s *movieSvc) DeleteMovie(actorID *primitive.ObjectID, id *primitive.ObjectID) error {
	actor, err := s.userRepo.GetUserByID(actorID)
	if err != nil {
		return err
	}

	if !HasPermission(actor, ResourceMovie, ActionDelete, nil) {
		return errors.New("unauthorized")
	}

	return s.repo.DeleteMovie(id)
}
