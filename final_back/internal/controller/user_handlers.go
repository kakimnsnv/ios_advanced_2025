package controller

import (
	"github.com/gin-gonic/gin"
	"github.com/kakimnsnv/ios_final_back/internal/models"
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
