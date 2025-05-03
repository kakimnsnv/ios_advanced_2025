package service

import (
	"github.com/kakimnsnv/ios_final_back/internal/errs"
	"github.com/kakimnsnv/ios_final_back/internal/models"
	"github.com/kakimnsnv/ios_final_back/internal/repository"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.uber.org/zap"
)

type ReviewService interface {
	ListReviewsByMovieID(actorID *primitive.ObjectID, movieID *primitive.ObjectID) ([]*models.Review, []*models.Review, error)
	ListMyReviews(actorID *primitive.ObjectID) ([]*models.Review, error)
	UpdateReview(actorID *primitive.ObjectID, reviewID *primitive.ObjectID, review *models.UpdateReviewRequest) error
	ListReviewCategories() ([]*models.ReviewCategory, error)
	CreateReview(actorID *primitive.ObjectID, review *models.CreateReviewRequest) (*primitive.ObjectID, error)
	DeleteReview(actorID *primitive.ObjectID, reviewID *primitive.ObjectID) error
}

type reviewSvc struct {
	log      *zap.Logger
	repo     repository.ReviewRepo
	userRepo repository.UserRepo
}

func NewReviewService(log *zap.Logger, repo repository.ReviewRepo, userRepo repository.UserRepo) ReviewService {
	return &reviewSvc{
		log:      log,
		repo:     repo,
		userRepo: userRepo,
	}
}

func (s *reviewSvc) ListReviewsByMovieID(actorID *primitive.ObjectID, movieID *primitive.ObjectID) ([]*models.Review, []*models.Review, error) {
	reviews, err := s.repo.ListReviewsByMovieID(actorID, movieID)
	if err != nil {
		return nil, nil, err
	}

	ownReviews, err := s.repo.ListOwnReviewsByMovieID(actorID, movieID)
	if err != nil {
		return nil, nil, err
	}

	return ownReviews, reviews, nil
}

func (s *reviewSvc) ListMyReviews(actorID *primitive.ObjectID) ([]*models.Review, error) {
	reviews, err := s.repo.ListMyReviews(actorID)
	if err != nil {
		return nil, err
	}
	return reviews, nil
}

func (s *reviewSvc) UpdateReview(actorID *primitive.ObjectID, reviewID *primitive.ObjectID, review *models.UpdateReviewRequest) error {
	actor, err := s.userRepo.GetUserByID(actorID)
	if err != nil {
		return err
	}

	updatingReview, err := s.repo.GetReviewByID(reviewID)
	if err != nil {
		return err
	}

	if !HasPermission(actor, ResourceReview, ActionUpdate, updatingReview) {
		return errs.Forbidden
	}

	updatingReview.Content = review.Content
	updatingReview.IsPrivate = review.IsPrivate
	updatingReview.ReviewCategoryID = review.ReviewCategoryID
	updatingReview.Rating = review.Rating

	if _, err = s.repo.UpdateReview(reviewID, updatingReview); err != nil {
		return err
	}
	return nil
}

func (s *reviewSvc) ListReviewCategories() ([]*models.ReviewCategory, error) {
	categories, err := s.repo.ListReviewCategories()
	if err != nil {
		return nil, err
	}
	return categories, nil
}

func (s *reviewSvc) CreateReview(actorID *primitive.ObjectID, req *models.CreateReviewRequest) (*primitive.ObjectID, error) {
	review := models.Review{
		OwnerID:          *actorID,
		MovieID:          req.MovieID,
		ReviewCategoryID: req.ReviewCategoryID,
		Content:          req.Content,
		IsPrivate:        req.IsPrivate,
		Rating:           req.Rating,
	}

	id, err := s.repo.CreateReview(&review)
	if err != nil {
		return nil, err
	}
	return id, nil
}

func (s *reviewSvc) DeleteReview(actorID *primitive.ObjectID, reviewID *primitive.ObjectID) error {
	actor, err := s.userRepo.GetUserByID(actorID)
	if err != nil {
		return err
	}

	review, err := s.repo.GetReviewByID(reviewID)
	if err != nil {
		return err
	}

	if !HasPermission(actor, ResourceReview, ActionDelete, review) {
		return errs.Forbidden
	}

	if err := s.repo.DeleteReview(reviewID); err != nil {
		return err
	}
	return nil
}
