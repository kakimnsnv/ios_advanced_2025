package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Review struct {
	ID               *primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	MovieID          primitive.ObjectID  `json:"movieId" bson:"movieId"`
	OwnerID          primitive.ObjectID  `json:"ownerId" bson:"ownerId"`
	ReviewCategoryID primitive.ObjectID  `json:"reviewCategoryId" bson:"reviewCategoryId"`
	Rating           int                 `json:"rating" bson:"rating"`
	Content          *string             `json:"content,omitempty" bson:"content,omitempty"`
	Created          *primitive.DateTime `json:"created,omitempty" bson:"created,omitempty"`
	Updated          *primitive.DateTime `json:"updated,omitempty" bson:"updated,omitempty"`
	Deleted          *primitive.DateTime `json:"deleted,omitempty" bson:"deleted,omitempty"`
	IsPrivate        bool                `json:"isPrivate" bson:"isPrivate"`
}

type CreateReviewRequest struct {
	MovieID          primitive.ObjectID `json:"movieId"`
	ReviewCategoryID primitive.ObjectID `json:"reviewCategoryId" bson:"reviewCategoryId"`
	Rating           int                `json:"rating" binding:"required,min=1,max=10"`
	Content          *string            `json:"content,omitempty" binding:"omitempty,max=500"`
	IsPrivate        bool               `json:"isPrivate"`
}
