# Deployment Guide for Photo Scavenger Hunt

This guide will help you deploy the Photo Scavenger Hunt app to Fly.io.

## Prerequisites

1. Install the Fly CLI: https://fly.io/docs/hands-on/install-flyctl/
2. Create a Fly.io account: https://fly.io/app/sign-up
3. Login to Fly.io: `fly auth login`

## Deployment Steps

### 1. Initialize Fly.io App

```bash
fly launch
```

This will:
- Create a new app on Fly.io
- Generate a `fly.toml` configuration file
- Set up the necessary environment variables

### 2. Create a Volume for Database

```bash
fly volumes create photo_scavenger_data --region ord --size 1
```

This creates a persistent volume to store the SQLite database.

### 3. Set Environment Variables

```bash
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)
fly secrets set PHX_HOST=your-app-name.fly.dev
```

### 4. Deploy the Application

```bash
fly deploy
```

### 5. Run Database Migrations

```bash
fly ssh console
```

Then inside the console:
```bash
bin/photo_scavenger eval "PhotoScavenger.Release.migrate"
bin/photo_scavenger eval "PhotoScavenger.Release.seed"
```

### 6. Open the Application

```bash
fly open
```

## Environment Variables

The following environment variables are configured in `fly.toml`:

- `PHX_SERVER=true` - Enables the Phoenix server
- `DATABASE_PATH=/data/photo_scavenger.db` - Path to the SQLite database
- `POOL_SIZE=5` - Database connection pool size

## Database

The app uses SQLite with a persistent volume mounted at `/data`. The database file is stored at `/data/photo_scavenger.db`.

## File Uploads

Uploaded photos are stored in `priv/static/uploads/` and are served as static files. In production, these files are stored in the container's filesystem.

## Monitoring

You can monitor your app using:

```bash
fly logs
fly status
fly metrics
```

## Scaling

To scale your app:

```bash
fly scale count 2
```

## Troubleshooting

### Database Issues

If you need to reset the database:

```bash
fly ssh console
rm /data/photo_scavenger.db
bin/photo_scavenger eval "PhotoScavenger.Release.migrate"
bin/photo_scavenger eval "PhotoScavenger.Release.seed"
```

### File Upload Issues

If file uploads aren't working, check that the uploads directory exists:

```bash
fly ssh console
mkdir -p priv/static/uploads
```

## Security Notes

- The app uses HTTPS by default on Fly.io
- File uploads are stored in the container's filesystem (not persistent)
- Consider implementing file cleanup for uploaded photos
- The admin panel is accessible at `/admin/review` - consider adding authentication

## Cost Optimization

- The app is configured with minimal resources (256MB RAM, 1 CPU)
- Auto-scaling is enabled (machines stop when not in use)
- Consider using a smaller instance type for development/testing
