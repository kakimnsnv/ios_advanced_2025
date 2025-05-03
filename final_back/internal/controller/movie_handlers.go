package controller

import (
	"github.com/gin-gonic/gin"
	"github.com/kakimnsnv/ios_final_back/internal/models"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.uber.org/zap"
)

func (ctrl *controller) ListMovies(c *gin.Context) {
	movies, err := ctrl.movieSvc.ListMovies()
	if err != nil {
		ctrl.log.Error("failed to list movies", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to list movies"})
		return
	}

	c.JSON(200, movies)
}

func (ctrl *controller) GetMovie(c *gin.Context) {
	id := c.Param("id")
	idObj, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		ctrl.log.Error("failed to convert id to objectID", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid id"})
		return
	}

	movie, err := ctrl.movieSvc.GetMovie(&idObj)
	if err != nil {
		ctrl.log.Error("failed to get movie", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to get movie"})
		return
	}

	c.JSON(200, movie)
}

func (ctrl *controller) CreateMovie(c *gin.Context) {
	actorID, ok := c.Get("userID")
	if !ok {
		ctrl.log.Error("userID is nil")
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	var movie models.CreateMovieRequest
	if err := c.ShouldBindJSON(&movie); err != nil {
		ctrl.log.Error("failed to bind request", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}

	res, err := ctrl.movieSvc.CreateMovie(actorID.(*primitive.ObjectID), &movie)
	if err != nil {
		ctrl.log.Error("failed to create movie", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to create movie"})
		return
	}
	c.JSON(201, res)
}

func (ctrl *controller) UpdateMovie(c *gin.Context) {
	id := c.Param("id")
	idObj, err := primitive.ObjectIDFromHex(id)
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

	var movie models.UpdateMovieRequest
	if err := c.ShouldBindJSON(&movie); err != nil {
		ctrl.log.Error("failed to bind request", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}

	res, err := ctrl.movieSvc.UpdateMovie(actorID.(*primitive.ObjectID), &idObj, &movie)
	if err != nil {
		ctrl.log.Error("failed to update movie", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to update movie"})
		return
	}
	c.JSON(200, res)
}

func (ctrl *controller) DeleteMovie(c *gin.Context) {
	id := c.Param("id")
	idObj, err := primitive.ObjectIDFromHex(id)
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

	err = ctrl.movieSvc.DeleteMovie(actorID.(*primitive.ObjectID), &idObj)
	if err != nil {
		ctrl.log.Error("failed to delete movie", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to delete movie"})
		return
	}
	c.JSON(200, gin.H{"message": "Movie deleted successfully"})
}
