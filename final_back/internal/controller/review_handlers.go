package controller

import (
	"github.com/gin-gonic/gin"
	"github.com/kakimnsnv/ios_final_back/internal/models"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.uber.org/zap"
)

func (ctrl *controller) ListReviewsByMovieID(c *gin.Context) {
	movieIDStr := c.Param("movieId")
	movieID, err := primitive.ObjectIDFromHex(movieIDStr)
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

	ownReviews, reviews, err := ctrl.reviewSvc.ListReviewsByMovieID(actorID.(*primitive.ObjectID), &movieID)
	if err != nil {
		ctrl.log.Error("failed to list reviews by movie ID", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to list reviews by movie ID"})
		return
	}
	c.JSON(200, gin.H{"ownReviews": ownReviews, "reviews": reviews})
}

func (ctrl *controller) ListMyReviews(c *gin.Context) {
	actorID, ok := c.Get("userID")
	if !ok {
		ctrl.log.Error("userID is nil")
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	reviews, err := ctrl.reviewSvc.ListMyReviews(actorID.(*primitive.ObjectID))
	if err != nil {
		ctrl.log.Error("failed to list my reviews", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to list my reviews"})
		return
	}
	c.JSON(200, reviews)
}

func (ctrl *controller) UpdateReview(c *gin.Context) {
	actorID, ok := c.Get("userID")
	if !ok {
		ctrl.log.Error("userID is nil")
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	reviewIDStr := c.Param("id")
	reviewID, err := primitive.ObjectIDFromHex(reviewIDStr)
	if err != nil {
		ctrl.log.Error("failed to convert id to objectID", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid id"})
		return
	}

	var review models.UpdateReviewRequest
	if err := c.ShouldBindJSON(&review); err != nil {
		ctrl.log.Error("failed to bind request", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}

	if err := ctrl.reviewSvc.UpdateReview(actorID.(*primitive.ObjectID), &reviewID, &review); err != nil {
		ctrl.log.Error("failed to update my review", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to update my review"})
		return
	}
	c.Status(200)
}

func (ctrl *controller) ListReviewCategories(c *gin.Context) {
	categories, err := ctrl.reviewSvc.ListReviewCategories()
	if err != nil {
		ctrl.log.Error("failed to list review categories", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to list review categories"})
		return
	}
	c.JSON(200, categories)
}

func (ctrl *controller) CreateReview(c *gin.Context) {
	actorID, ok := c.Get("userID")
	if !ok {
		ctrl.log.Error("userID is nil")
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	var review models.CreateReviewRequest
	if err := c.ShouldBindJSON(&review); err != nil {
		ctrl.log.Error("failed to bind request", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}

	id, err := ctrl.reviewSvc.CreateReview(actorID.(*primitive.ObjectID), &review)
	if err != nil {
		ctrl.log.Error("failed to create review", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to create review"})
		return
	}
	c.JSON(200, gin.H{"id": id})
}

func (ctrl *controller) DeleteReview(c *gin.Context) {
	actorID, ok := c.Get("userID")
	if !ok {
		ctrl.log.Error("userID is nil")
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	reviewIDStr := c.Param("id")
	reviewID, err := primitive.ObjectIDFromHex(reviewIDStr)
	if err != nil {
		ctrl.log.Error("failed to convert id to objectID", zap.Error(err))
		c.JSON(400, gin.H{"error": "Invalid id"})
		return
	}

	if err := ctrl.reviewSvc.DeleteReview(actorID.(*primitive.ObjectID), &reviewID); err != nil {
		ctrl.log.Error("failed to delete review", zap.Error(err))
		c.JSON(500, gin.H{"error": "Failed to delete review"})
		return
	}
	c.Status(200)
}
