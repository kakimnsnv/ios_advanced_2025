package controller

import (
	"github.com/gin-gonic/gin"
	"github.com/kakimnsnv/ios_final_back/internal/errs"
	"github.com/kakimnsnv/ios_final_back/internal/models"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.uber.org/zap"
)

func (ctrl *controller) RegisterUser(c *gin.Context) {
	var req models.CreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		ctrl.log.Error("failed to bind request", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid input"})
		return
	}

	token, refreshToken, err := ctrl.usersvc.CreateUser(req)
	if err != nil {
		ctrl.log.Error("failed to create user", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to create user"})
		return
	}

	c.JSON(200, gin.H{
		"token":        token,
		"refreshToken": refreshToken,
	})
}

func (ctrl *controller) LoginUser(c *gin.Context) {
	var req models.UserCredentials
	if err := c.ShouldBindJSON(&req); err != nil {
		ctrl.log.Error("failed to bind request", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid input"})
		return
	}

	token, refreshToken, err := ctrl.usersvc.LoginUser(req)
	if err != nil {
		ctrl.log.Error("failed to login user", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to login user"})
		return
	}

	c.JSON(200, gin.H{
		"token":        token,
		"refreshToken": refreshToken,
	})
}

func (ctrl *controller) RefreshToken(c *gin.Context) {
	var req models.RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		ctrl.log.Error("failed to bind request", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid input"})
		return
	}

	token, refreshToken, err := ctrl.jwtSvc.RefreshToken(req.RefreshToken)
	if err != nil {
		ctrl.log.Error("failed to refresh token", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to refresh token"})
		return
	}

	c.JSON(200, gin.H{
		"token":        token,
		"refreshToken": refreshToken,
	})
}

func (ctrl *controller) GetMe(c *gin.Context) {
	userID, ok := c.Get("userID")
	if !ok {
		ctrl.log.Error("userID is nil")
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	user, err := ctrl.usersvc.GetUserByID(userID.(*primitive.ObjectID))
	if err != nil {
		ctrl.log.Error("failed to get user by ID", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to get user"})
		return
	}

	c.JSON(200, user)
}

func (ctrl *controller) UpdateMe(c *gin.Context) {
	userID, ok := c.Get("userID")
	if !ok {
		ctrl.log.Error("userID is nil")
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	var req models.UpdateMeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		ctrl.log.Error("failed to bind request", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid input"})
		return
	}

	user, err := ctrl.usersvc.UpdateMe(userID.(*primitive.ObjectID), req)
	if err != nil {
		ctrl.log.Error("failed to update user", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to update user"})
		return
	}

	c.JSON(200, user)
}

func (ctrl *controller) DeleteMe(c *gin.Context) {
	userID, ok := c.Get("userID")
	if !ok {
		ctrl.log.Error("userID is nil")
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	err := ctrl.usersvc.DeleteMe(userID.(*primitive.ObjectID))
	if err != nil {
		ctrl.log.Error("failed to delete user", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to delete user"})
		return
	}

	c.JSON(200, gin.H{"message": "User deleted successfully"})
}

func (ctrl *controller) GetUser(c *gin.Context) {
	userID, ok := c.Get("userID")
	if !ok {
		ctrl.log.Error("userID is nil")
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	user, err := ctrl.usersvc.GetUserByID(userID.(*primitive.ObjectID))
	if err != nil {
		ctrl.log.Error("failed to get user by ID", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to get user"})
		return
	}

	c.JSON(200, user)
}

func (ctrl *controller) ListUsers(c *gin.Context) {
	users, err := ctrl.usersvc.ListUsers()
	if err != nil {
		ctrl.log.Error("failed to list users", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to list users"})
		return
	}

	c.JSON(200, users)
}

func (ctrl *controller) UpdateUser(c *gin.Context) {
	id := c.Param("id")
	targetID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		ctrl.log.Error("failed to convert id to objectID", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid id"})
		return
	}

	actorID, ok := c.Get("userID")
	if !ok {
		ctrl.log.Error("userID is nil")
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	var req models.UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		ctrl.log.Error("failed to bind request", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid input"})
		return
	}

	user, err := ctrl.usersvc.UpdateUser(actorID.(*primitive.ObjectID), &targetID, req)
	if err != nil {
		if err == errs.Forbidden {
			ctrl.log.Error("user does not have permission to update user", zap.Error(err))
			c.JSON(403, gin.H{"error": "Forbidden"})
			return
		}
		ctrl.log.Error("failed to update user", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to update user"})
		return
	}

	c.JSON(200, user)
}

func (ctrl *controller) DeleteUser(c *gin.Context) {
	id := c.Param("id")
	targetID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		ctrl.log.Error("failed to convert id to objectID", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid id"})
		return
	}

	actorID, ok := c.Get("userID")
	if !ok {
		ctrl.log.Error("userID is nil")
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	if err := ctrl.usersvc.DeleteUser(actorID.(*primitive.ObjectID), &targetID); err != nil {
		if err == errs.Forbidden {
			ctrl.log.Error("user does not have permission to update user", zap.Error(err))
			c.JSON(403, gin.H{"error": "Forbidden"})
			return
		}
		ctrl.log.Error("failed to update user", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to update user"})
		return
	}

	c.Status(200)
}
