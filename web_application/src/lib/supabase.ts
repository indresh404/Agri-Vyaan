import { createClient } from '@supabase/supabase-js';
import type { DroneOperation, CropFinding } from '../types';

// ── Agrivyaan / SIH2026 Supabase Project ─────────────────────────────────────
const SUPABASE_URL =
  (import.meta.env && import.meta.env.VITE_SUPABASE_URL) ||
  'https://zxclczrpyrslkmoqmwhg.supabase.co';

const SUPABASE_ANON_KEY =
  (import.meta.env && import.meta.env.VITE_SUPABASE_ANON_KEY) ||
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp4Y2xjenJweXJzbGttb3Ftd2hnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg4ODkwNjgsImV4cCI6MjEwNDQ2NTA2OH0.cvvJxZ3CpzXihc8vYoedpj09zxZGLC4V2rEySdf9Bfg';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ── Raw DB Row Types ──────────────────────────────────────────────────────────
export interface BookingRow {
  booking_id: string;
  fid: string;
  fieldid: string;
  field_name: string | null;
  booking_datetime: string;
  status: string;
}

export interface FieldRow {
  fieldid: string;
  fid: string;
  user_name: string;
  field_name: string;
  field_number: number;
  crop_name: string;
  area: number;
  latitude: number;
  longitude: number;
}

export interface UserRow {
  fid: string;
  name: string;
  phone: string | null;
  location: string | null;
  email: string | null;
  main_crop: string | null;
}

// ── Data Fetching Helpers ─────────────────────────────────────────────────────

/** Fetch all bookings ordered by booking_datetime desc */
export async function fetchAllBookings(): Promise<BookingRow[]> {
  const { data, error } = await supabase
    .from('bookings')
    .select('*')
    .order('booking_datetime', { ascending: false });
  if (error) {
    console.error('[Supabase] fetchAllBookings error:', error.message);
    return [];
  }
  return (data as BookingRow[]) || [];
}

/** Fetch all fields */
export async function fetchAllFields(): Promise<FieldRow[]> {
  const { data, error } = await supabase
    .from('fields')
    .select('*');
  if (error) {
    console.error('[Supabase] fetchAllFields error:', error.message);
    return [];
  }
  return (data as FieldRow[]) || [];
}

/** Fetch all users */
export async function fetchAllUsers(): Promise<UserRow[]> {
  const { data, error } = await supabase
    .from('users')
    .select('fid, name, phone, location, email, main_crop');
  if (error) {
    console.error('[Supabase] fetchAllUsers error:', error.message);
    return [];
  }
  return (data as UserRow[]) || [];
}

/** Update a booking's status */
export async function updateBookingStatus(bookingId: string, status: string): Promise<void> {
  const { error } = await supabase
    .from('bookings')
    .update({ status })
    .eq('booking_id', bookingId);
  if (error) {
    console.error('[Supabase] updateBookingStatus error:', error.message);
  }
}

/** Subscribe to realtime inserts & updates on the bookings table */
export function subscribeToBookings(onchange: () => void) {
  const channel = supabase
    .channel('agrivyaan-bookings-realtime')
    .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'bookings' }, onchange)
    .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'bookings' }, onchange)
    .subscribe();
  return () => {
    supabase.removeChannel(channel);
  };
}

// ── Auth Service Wrappers ─────────────────────────────────────────────────────
export const supabaseAuthService = {
  async getSessionUser() {
    const { data: { session } } = await supabase.auth.getSession();
    return session?.user || {
      id: 'op-04',
      email: 'operator.vikram@agrivyaan.in',
      user_metadata: { name: 'Vikram Sharma', role: 'Operator Supervisor', badge: 'Operator #04' }
    };
  },
  async signIn(email: string) {
    return await supabase.auth.signInWithOtp({ email });
  },
  async signOut() {
    return await supabase.auth.signOut();
  }
};

// ── Legacy Realtime Telemetry (Operations / Findings tables) ──────────────────
export const subscribeToRealtimeTelemetry = (
  onOperationUpdate: (op: Partial<DroneOperation>) => void,
  onFindingUpdate: (finding: Partial<CropFinding>) => void
) => {
  const channel = supabase
    .channel('agriswarm-operations-realtime')
    .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'operations' }, (payload) => {
      onOperationUpdate(payload.new as Partial<DroneOperation>);
    })
    .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'findings' }, (payload) => {
      onFindingUpdate(payload.new as Partial<CropFinding>);
    })
    .subscribe();
  return () => {
    supabase.removeChannel(channel);
  };
};

// ── Storage Service ───────────────────────────────────────────────────────────
export const supabaseStorageService = {
  async uploadReportPdf(reportId: string, pdfBlob: Blob) {
    const filePath = `reports/${reportId}.pdf`;
    const { data, error } = await supabase.storage
      .from('agriswarm-reports')
      .upload(filePath, pdfBlob, { upsert: true });
    if (error) {
      console.warn('Supabase storage fallback:', error.message);
      return `https://agriswarm-storage.local/reports/${reportId}.pdf`;
    }
    return data.path;
  },
  async getPublicUrl(path: string) {
    const { data } = supabase.storage.from('agriswarm-reports').getPublicUrl(path);
    return data.publicUrl;
  }
};
