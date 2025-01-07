# SignalR Chatroom Demo with Godot

a simple proof of concept for **signalR** as a backend for a **Godot4** game

## What It Does

- **Backend**: SignalR handles real-time message updates and broadcasts.
- **Frontend**: Godot connects to the SignalR backend, sending and receiving messages in real time.
- **Live Chat**: Messages show up instantly for everyone connected.

## How to Run It

### Backend (SignalR)

1. Go to the `GameServerAPI` folder:
   cd GameServerAPI
   dotnet run
   should be running on local host:5054

### Frontend
just run the project.godot file create as many instances as you need and test it out