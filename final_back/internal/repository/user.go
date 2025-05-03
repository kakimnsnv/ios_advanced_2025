package repository

import (
	"context"

	"github.com/kakimnsnv/ios_final_back/internal/models"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.uber.org/zap"
)

type UserRepo interface {
	GetUserByID(userID primitive.ObjectID) (*models.User, error)
	GetUserByUsername(username string) (*models.User, error)
	CreateUser(req *models.User) (primitive.ObjectID, error)
}

type userRepo struct {
	collection *mongo.Collection
}

func NewUserRepo(log *zap.Logger, collNames map[string]int, db *mongo.Database) UserRepo {
	var collectionName = "users"

	if _, exists := collNames[collectionName]; !exists {
		if err := db.CreateCollection(context.TODO(), collectionName); err != nil {
			log.Fatal("couldn't initialize repository: ", zap.Error(err))
		}
	}

	return &userRepo{
		collection: db.Collection(collectionName),
	}
}

func (r *userRepo) GetUserByID(userID primitive.ObjectID) (*models.User, error) {
	var user models.User
	err := r.collection.FindOne(context.TODO(), bson.M{"_id": userID}).Decode(&user)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepo) GetUserByUsername(username string) (*models.User, error) {
	var user models.User
	err := r.collection.FindOne(context.TODO(), bson.M{"username": username}).Decode(&user)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepo) CreateUser(req *models.User) (primitive.ObjectID, error) {
	res, err := r.collection.InsertOne(context.TODO(), req)
	if err != nil {
		return primitive.NilObjectID, err
	}
	return res.InsertedID.(primitive.ObjectID), nil
}
