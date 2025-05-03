package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Movie struct {
	ID         *primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Title      string              `json:"title,omitempty" bson:"title,omitempty"`
	Year       int                 `json:"year,omitempty" bson:"year,omitempty"`
	DirectorID *primitive.ObjectID `json:"directorId,omitempty" bson:"directorId,omitempty"`
	GenreID    *primitive.ObjectID `json:"genreId,omitempty" bson:"genreId,omitempty"`
	Rating     float64             `json:"rating,omitempty" bson:"rating,omitempty"`
	ImageURL   string              `json:"imageURL,omitempty" bson:"imageURL,omitempty"`
}

type CreateMovieRequest struct {
	Title      string              `json:"title" binding:"required"`
	Year       int                 `json:"year" binding:"required"`
	DirectorID *primitive.ObjectID `json:"directorId" binding:"required"`
	GenreID    *primitive.ObjectID `json:"genreId" binding:"required"`
	Rating     float64             `json:"rating" binding:"required"`
	ImageURL   string              `json:"imageURL" binding:"required"`
}

type UpdateMovieRequest struct {
	Title      *string             `json:"title,omitempty" binding:"omitempty,required"`
	Year       *int                `json:"year,omitempty" binding:"omitempty,required"`
	DirectorID *primitive.ObjectID `json:"directorId,omitempty" binding:"omitempty,required"`
	GenreID    *primitive.ObjectID `json:"genreId,omitempty" binding:"omitempty,required"`
	Rating     *float64            `json:"rating,omitempty" binding:"omitempty,required"`
	ImageURL   *string             `json:"imageURL,omitempty" binding:"omitempty,required"`
}
