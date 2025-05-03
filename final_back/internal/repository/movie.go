package repository

import (
	"context"

	"go.mongodb.org/mongo-driver/mongo"
	"go.uber.org/zap"
)

type MovieRepo interface {
}

type movieRepo struct {
	collection *mongo.Collection
}

func NewMovieRepo(log *zap.Logger, collNames map[string]int, db *mongo.Database) MovieRepo {
	var collectionName = "movies"

	if _, exists := collNames[collectionName]; !exists {
		if err := db.CreateCollection(context.TODO(), collectionName); err != nil {
			log.Fatal("couldn't initialize repository: ", zap.Error(err))
		}
	}

	return &movieRepo{
		collection: db.Collection(collectionName),
	}
}
