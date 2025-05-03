package repository

import (
	"context"

	"github.com/kakimnsnv/ios_final_back/internal/models"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.uber.org/zap"
)

type ReviewRepo interface {
	ListReviewsByMovieID(actorID *primitive.ObjectID, movieID *primitive.ObjectID) ([]*models.Review, error)
	ListOwnReviewsByMovieID(actorID *primitive.ObjectID, movieID *primitive.ObjectID) ([]*models.Review, error)
	ListMyReviews(actorID *primitive.ObjectID) ([]*models.Review, error)
	ListReviewCategories() ([]*models.ReviewCategory, error)
	UpdateReview(reviewID *primitive.ObjectID, review *models.Review) (*models.Review, error)
	GetReviewByID(reviewID *primitive.ObjectID) (*models.Review, error)
	CreateReview(review *models.Review) (*primitive.ObjectID, error)
	DeleteReview(reviewID *primitive.ObjectID) error
}

type reviewRepo struct {
	collection               *mongo.Collection
	reviewCategoryCollection *mongo.Collection
}

func NewReviewRepo(log *zap.Logger, collNames map[string]int, db *mongo.Database) ReviewRepo {
	var collectionName = "reviews"
	var reviewCategoryCollectionName = "reviewCategories"

	if _, exists := collNames[collectionName]; !exists {
		if err := db.CreateCollection(context.TODO(), collectionName); err != nil {
			log.Fatal("couldn't initialize repository: ", zap.Error(err))
		}
	}

	if _, exists := collNames[reviewCategoryCollectionName]; !exists {
		if err := db.CreateCollection(context.TODO(), reviewCategoryCollectionName); err != nil {
			log.Fatal("couldn't initialize repository: ", zap.Error(err))
		}
		db.Collection(reviewCategoryCollectionName).InsertMany(context.TODO(), []interface{}{
			models.ReviewCategory{
				Name: "Хочу пересмотеть",
			},
			models.ReviewCategory{
				Name: "Советую другим",
			},
			models.ReviewCategory{
				Name: "Только на один раз",
			},
		})

	}

	return &reviewRepo{
		collection:               db.Collection(collectionName),
		reviewCategoryCollection: db.Collection(reviewCategoryCollectionName),
	}
}

func (r *reviewRepo) ListReviewsByMovieID(actorID *primitive.ObjectID, movieID *primitive.ObjectID) ([]*models.Review, error) {
	cur, err := r.collection.Find(context.TODO(), bson.M{"movieID": movieID})
	if err != nil {
		return nil, err
	}

	var reviews []*models.Review
	if err := cur.All(context.TODO(), &reviews); err != nil {
		return nil, err
	}
	return reviews, nil
}

func (r *reviewRepo) ListOwnReviewsByMovieID(actorID *primitive.ObjectID, movieID *primitive.ObjectID) ([]*models.Review, error) {
	cur, err := r.collection.Find(context.TODO(), bson.M{"movieID": movieID, "userID": actorID})
	if err != nil {
		return nil, err
	}

	var reviews []*models.Review
	if err := cur.All(context.TODO(), &reviews); err != nil {
		return nil, err
	}
	return reviews, nil
}

func (r *reviewRepo) ListMyReviews(actorID *primitive.ObjectID) ([]*models.Review, error) {
	cur, err := r.collection.Find(context.TODO(), bson.M{"userID": actorID})
	if err != nil {
		return nil, err
	}

	var reviews []*models.Review
	if err := cur.All(context.TODO(), &reviews); err != nil {
		return nil, err
	}
	return reviews, nil
}

func (r *reviewRepo) ListReviewCategories() ([]*models.ReviewCategory, error) {
	cur, err := r.reviewCategoryCollection.Find(context.TODO(), bson.M{})
	if err != nil {
		return nil, err
	}

	var categories []*models.ReviewCategory
	if err := cur.All(context.TODO(), &categories); err != nil {
		return nil, err
	}
	return categories, nil
}

func (r *reviewRepo) UpdateReview(reviewID *primitive.ObjectID, review *models.Review) (*models.Review, error) {
	_, err := r.collection.UpdateOne(context.TODO(), bson.M{"_id": reviewID}, bson.M{"$set": review})
	if err != nil {
		return nil, err
	}
	return review, nil
}

func (r *reviewRepo) GetReviewByID(reviewID *primitive.ObjectID) (*models.Review, error) {
	var review models.Review
	err := r.collection.FindOne(context.TODO(), bson.M{"_id": reviewID}).Decode(&review)
	if err != nil {
		return nil, err
	}
	return &review, nil
}

func (r *reviewRepo) CreateReview(review *models.Review) (*primitive.ObjectID, error) {
	res, err := r.collection.InsertOne(context.TODO(), review)
	if err != nil {
		return nil, err
	}
	return res.InsertedID.(*primitive.ObjectID), nil
}

func (r *reviewRepo) DeleteReview(reviewID *primitive.ObjectID) error {
	_, err := r.collection.DeleteOne(context.TODO(), bson.M{"_id": reviewID})
	if err != nil {
		return err
	}
	return nil
}
