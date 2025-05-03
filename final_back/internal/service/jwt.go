package service

import (
	"time"

	"github.com/golang-jwt/jwt/v4"
	"github.com/kakimnsnv/ios_final_back/internal/models"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type JWTService interface {
	CreateJWT(userID primitive.ObjectID, roles []models.Role) (string, string, error)
	RefreshToken(tokenString string) (string, string, error)
	ParseJWT(tokenString string) (*primitive.ObjectID, []models.Role, error)
}

type jwtService struct {
	secretKey            string
	tokenDuration        time.Duration
	refreshTokenDuration time.Duration
}

func NewJWTService(secretKey string, tokenDuration time.Duration, refreshTokenDuration time.Duration) JWTService {
	return &jwtService{
		secretKey:            secretKey,
		tokenDuration:        tokenDuration,
		refreshTokenDuration: refreshTokenDuration,
	}

}

func (s *jwtService) CreateJWT(userID primitive.ObjectID, roles []models.Role) (string, string, error) {
	claims := jwt.MapClaims{
		"iss":    "ios_final_back",
		"userID": userID,
		"roles":  roles,
		"exp":    time.Now().Add(s.tokenDuration).Unix(),
		"iat":    time.Now().Unix(),
	}
	refreshClaims := jwt.MapClaims{
		"iss":    "ios_final_back",
		"userID": userID,
		"roles":  roles,
		"exp":    time.Now().Add(s.refreshTokenDuration).Unix(),
		"iat":    time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)

	signedToken, err := token.SignedString([]byte(s.secretKey))
	if err != nil {
		return "", "", err
	}
	signedRefreshToken, err := refreshToken.SignedString([]byte(s.secretKey))
	if err != nil {
		return "", "", err
	}

	return signedToken, signedRefreshToken, nil
}

func (s *jwtService) RefreshToken(tokenString string) (string, string, error) {
	token, err := jwt.Parse(tokenString, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(s.secretKey), nil
	})
	if err != nil {
		return "", "", err
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return s.CreateJWT(claims["userID"].(primitive.ObjectID), claims["roles"].([]models.Role))
	}

	return "", "", jwt.ErrTokenInvalidClaims
}

func (s *jwtService) ParseJWT(tokenString string) (*primitive.ObjectID, []models.Role, error) {
	token, err := jwt.Parse(tokenString, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(s.secretKey), nil
	})
	if err != nil {
		return nil, nil, err
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		userID, err := primitive.ObjectIDFromHex(claims["userID"].(string))
		if err != nil {
			return nil, nil, err
		}

		return &userID, claims["roles"].([]models.Role), nil
	}

	return nil, nil, jwt.ErrTokenInvalidClaims
}
