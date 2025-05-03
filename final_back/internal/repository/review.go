package repository

import (
	"context"

	"go.mongodb.org/mongo-driver/mongo"
	"go.uber.org/zap"
)

type ReviewRepo interface {
}

type reviewRepo struct {
	collection *mongo.Collection
}

func NewReviewRepo(log *zap.Logger, collNames map[string]int, db *mongo.Database) ReviewRepo {
	var collectionName = "reviews"

	if _, exists := collNames[collectionName]; !exists {
		if err := db.CreateCollection(context.TODO(), collectionName); err != nil {
			log.Fatal("couldn't initialize repository: ", zap.Error(err))
		}
	}

	return &reviewRepo{
		collection: db.Collection(collectionName),
	}
}
