create database Gemini_Club_Database;
use Gemini_Club_Database;

create table Account_Details (
    Username varchar(50) primary key,
    Position varchar(50),
    Passwrd varchar(50) 
);

create table Mentee_Details (
    Roll_Number int primary key ,
    Mentee_name varchar(20)
);

create table Mentee_Domain (
    Roll_Number int primary key ,
    web char(1) ,
    app char(1) ,
    sysad char(1) ,
    foreign key (Roll_Number) references Mentee_Details(Roll_Number)
);

create table Mentee_Task (
    Roll_Number int ,
    domain varchar(20) ,
    task_number smallint,
    submitted varchar(20) default null,
    completed varchar(20) default null,
    primary key(Roll_Number, domain, task_number),
    foreign key (Roll_Number) references Mentee_Domain(Roll_Number)
);


create table Mentor_Details (
    Mentor_name varchar(20) primary key,
    domain varchar (5)
);

create table Mentor_Allocation (
    Roll_Number int ,
    Mentor_name varchar(20) ,
    foreign key (Roll_Number) references Mentee_Domain(Roll_Number),
    foreign key (Mentor_name) references Mentor_Details(Mentor_name)
);

create table Mentee_Not_Submit (
    Roll_Number int ,
    domain varchar (5) ,
    task_number smallint ,
    foreign key (Roll_Number) references Mentee_Domain(Roll_Number)
);



