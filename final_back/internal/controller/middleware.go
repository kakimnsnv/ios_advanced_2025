package controller

import (
	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

func (ctrl *controller) AuthenticateMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := c.Request.Header.Get("Authorization")
		if token == "" {
			c.Next()
			return
		}

		userID, roles, err := ctrl.jwtSvc.ParseJWT(token)
		if userID != nil {
			c.Set("userID", *userID)
		}
		if roles != nil {
			c.Set("roles", roles)
		}
		ctrl.log.Warn("JWT token parsing error", zap.Error(err))
		c.Next()
	}
}
