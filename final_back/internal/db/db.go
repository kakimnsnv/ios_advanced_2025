package db

import (
	"context"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.uber.org/zap"
)

func New(log *zap.Logger, uri, db string) (*mongo.Database, *mongo.Client, map[string]int) {
	mongoClient, err := mongo.Connect(context.TODO(), options.Client().ApplyURI(uri))
	if err != nil {
		log.Fatal("couldn't connect to mongodb", zap.Error(err))
	}

	mongoDB := mongoClient.Database(db)
	collNames, _ := mongoDB.ListCollectionNames(context.TODO(), bson.M{})
	collectionsNames := make(map[string]int)
	for _, collName := range collNames {
		collectionsNames[collName]++
	}
	return mongoDB, mongoClient, collectionsNames
}
