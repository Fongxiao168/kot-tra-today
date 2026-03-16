-- Add free trial columns to profiles table
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS free_trial_enabled BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS free_trial_start TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS free_trial_end TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days');

-- Update existing users who don't have free trial set yet
UPDATE profiles 
SET free_trial_enabled = TRUE,
    free_trial_start = created_at,
    free_trial_end = created_at + INTERVAL '7 days'
WHERE free_trial_enabled IS NULL OR free_trial_enabled = FALSE;

-- Update handle_new_user function to auto-assign 7-day free trial for every new user
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role, full_name, free_trial_enabled, free_trial_start, free_trial_end)
  VALUES (
    new.id, 
    new.email, 
    'user',
    new.raw_user_meta_data->>'full_name',
    TRUE,
    NOW(),
    NOW() + INTERVAL '7 days'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Allow admins to update free trial fields via RLS (uses existing admin policies)
-- No additional RLS needed since profiles already have admin update policies.
