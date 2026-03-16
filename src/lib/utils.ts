import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import type { Profile } from "../types";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function hasActiveAccess(profile: Profile | null): boolean {
  if (!profile) return false;
  if (profile.is_premium) return true;
  if (profile.free_trial_enabled && profile.free_trial_end) {
    return new Date(profile.free_trial_end) > new Date();
  }
  return false;
}
