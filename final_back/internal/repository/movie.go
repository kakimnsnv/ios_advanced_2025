package repository

import (
	"context"

	"github.com/kakimnsnv/ios_final_back/internal/models"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.uber.org/zap"
)

type MovieRepo interface {
	ListMovies() ([]*models.Movie, error)
	GetMovie(id *primitive.ObjectID) (*models.Movie, error)
	CreateMovie(movie *models.CreateMovieRequest) (*primitive.ObjectID, error)
	UpdateMovie(id *primitive.ObjectID, movie *models.UpdateMovieRequest) (*models.Movie, error)
	DeleteMovie(id *primitive.ObjectID) error
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

func (r *movieRepo) ListMovies() ([]*models.Movie, error) {
	cur, err := r.collection.Find(context.TODO(), bson.M{})
	if err != nil {
		return nil, err
	}

	var movies []*models.Movie
	if err := cur.All(context.TODO(), &movies); err != nil {
		return nil, err
	}
	return movies, nil
}

func (r *movieRepo) GetMovie(id *primitive.ObjectID) (*models.Movie, error) {
	var movie models.Movie
	err := r.collection.FindOne(context.TODO(), bson.M{"_id": id}).Decode(&movie)
	if err != nil {
		return nil, err
	}
	return &movie, nil
}

func (r *movieRepo) CreateMovie(movie *models.CreateMovieRequest) (*primitive.ObjectID, error) {
	res, err := r.collection.InsertOne(context.TODO(), movie)
	if err != nil {
		return nil, err
	}

	return res.InsertedID.(*primitive.ObjectID), nil
}

func (r *movieRepo) UpdateMovie(id *primitive.ObjectID, movie *models.UpdateMovieRequest) (*models.Movie, error) {
	var updatedMovie models.Movie
	err := r.collection.FindOneAndUpdate(context.TODO(), bson.M{"_id": id}, bson.M{"$set": movie}).Decode(&updatedMovie)
	if err != nil {
		return nil, err
	}
	return &updatedMovie, nil
}

func (r *movieRepo) DeleteMovie(id *primitive.ObjectID) error {
	_, err := r.collection.DeleteOne(context.TODO(), bson.M{"_id": id})
	if err != nil {
		return err
	}
	return nil
}
