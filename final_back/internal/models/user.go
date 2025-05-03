package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type User struct {
	ID           *primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Username     string              `json:"username,omitempty" bson:"username,omitempty"`
	PasswordHash []byte              `json:"passwordHash,omitempty" bson:"passwordHash,omitempty"`
	Email        string              `json:"email,omitempty" bson:"email,omitempty"`
	Roles        []Role              `json:"roles" bson:"roles"`
}

type CreateUserRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
}

type UserCredentials struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type Tokens struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}
