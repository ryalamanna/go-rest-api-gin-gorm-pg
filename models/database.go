package models

import (
	"fmt"
	"go-rest-api/config"
	"strings"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
)

var DB *gorm.DB

func ConnectDatabase() {
	var err error
	config.LoadConfig()

	dsn := fmt.Sprintf("host=%s port=%s user=%s dbname=%s password=%s sslmode=disable",
		config.AppConfig.DBHost,
		config.AppConfig.DBPort,
		config.AppConfig.DBUser,
		config.AppConfig.DBName,
		strings.TrimSpace(config.AppConfig.DBPassword),
	)

	fmt.Printf("Postgres DSN: %+v\n", dsn)

	DB, err = gorm.Open("postgres", dsn)
	if err != nil {
		panic(fmt.Sprintf("Failed to connect to database! Error: %v", err))
	}

	DB.AutoMigrate(&Product{})
}
