//Things to Do
//Cookies
//MYSQL
//POST Request for Password
//GET Requests for Posts
//Maybe Search By Hashtags?
require('dotenv').config();
const express = require("express");
const bodyParser = require("body-parser");
const cookieParser = require('cookie-parser');
const mysql = require('mysql');
const bcrypt = require('bcrypt');
const randomatic = require('randomatic');
const cors = require("cors");

const app = express();
app.use(express.static("public"));
app.use(cors(
  {
    origin: 'http://localhost:3000',
    // credentials: true,
    optionsSuccessStatus: 200 // some legacy browsers (IE11, various SmartTVs) choke on 204
  }
));
app.use(bodyParser.urlencoded({
  extended: true
}));
app.use(function(req, res, next) {
res.header('Content-Type', 'application/json;charset=UTF-8')
res.header('Access-Control-Allow-Credentials', true)
res.header(
  'Access-Control-Allow-Headers',
  'Origin, X-Requested-With, Content-Type, Accept'
)
next()
})
app.use(bodyParser.json());
app.use(cookieParser());
var connection = mysql.createConnection({
  host: process.env.HOST,
  user: process.env.USER,
  password: process.env.PASSWORD,
  database: process.env.DATABASE,
  multipleStatements: true
})
connection.connect();

// Get All Posts
app.get("/posts",function(req,res){
  var sQuery = "SELECT * FROM posts WHERE visibility != 'hidden' AND visibility != 'private';"
  connection.query(sQuery,[],function(err,results,fields){
    if (err){
      return res.status(200).json({
        status: -1,
        message: err
      })
    } else if (results){
      console.log(results);
      var toPrep = {};
      for (let i = 0; i < results.length; i++){
        toPrep[i] = {
          title: results[i].title,
          userID: results[i].userID,
          content: results[i].content,
          subDate: results[i].subDate
        }
      }
      return res.status(200).json({
        status: 0,
        message: "Request Received.",
        contents: toPrep
      })
    }
  })
})
app.route("/post")
  //Retrieve Single Post
  .get(function(req,res){
    if (!req.query.postID){
      return res.status(200).json({
        status: -1,
        message: "Post ID Not Given."
      })
    }
    var sQuery = "SELECT * FROM posts WHERE postID = ?";
    connection.query(sQuery,[req.query.postid],function(err,results,fields){
      if (err){
        console.log(err);
        return res.status(200).json({
          status: -1,
          message: err
        })
      }else{
        if (results.length === 0){
          return res.status(200).json({
            status: -2,
            message: "There was no post with that ID."
          })
        }else{
          console.log(results[0].visibility);
          if (results[0].visibility !== 'private' || results[0].visibility !== 'hidden'){
            return res.status(200).json({
              status: 0,
              title: results[0].title,
              userID: results[0].userID,
              content: results[0].content,
              subDate: results[0].subDate
            })
          }
          else{
            //FIX THIS: return based on permissions
          }
        }
      }
    })
  })
  //Change Post Visibility to Hidden
  .delete(function(req,res){
    //FIX THIS: Will Need to Establish Permissions
    if (!req.query.postID){
      return res.status(200).json({
        status: -1,
        message: "Post ID Not Given."
      })
    }
    //If user is admin or mod, allow regardless
    //IF user is owner, Allow
    //If user not logged in or not owner, disallow
    var uQuery = `
      UPDATE posts
      SET visibility = "hidden"
      WHERE postID = 3;
      `;
    connection.query(uQuery,[req.query.postid],function(err,results,fields){
      if (err){
        console.log(err);
        return res.status(200).json({
          status: -1,
          message: err
        })
      }
      else{
        if (results.length == 0){
          return res.status(200).json({
            status: -1,
            message: "Could not find a post with that ID."
          })
        }
        else{
          return res.status(200).json({
            status: 0,
            message: "Update Occured."
          })
        }
      }
    })
  })
  //Add Single POST
  .put(function(req,res){

  })
  //Edit Single POST
  .patch(function(req,res){
    //FIX THIS: Do Later, Im not sure how I want this
  })
// Register Account
app.post("/register",function(req,res){

})
app.post("/login",function(req,res){

})

app.route("/user")
  //Get User and Associated Posts
  .get(function(req,res){

  })
  //Edit User Info
  .patch(function(req,res){

  })
  //Delete User (and maybe posts)
  .delete(function(req,res){

  })

app.listen(3001, function() {
  console.log("Server Started.")
});