import { createClient } from '@supabase/supabase-js';
import type { DroneOperation, CropFinding } from '../types';

// Fallback configuration for SIH 2026 local prototype & cloud deployment
const SUPABASE_URL = (import.meta.env && import.meta.env.VITE_SUPABASE_URL) || 'https://agriswarm-platform.supabase.co';
const SUPABASE_ANON_KEY = (import.meta.env && import.meta.env.VITE_SUPABASE_ANON_KEY) || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFncmlzd2FybSIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzA0MDY3MjAwLCJleHAiOjIwMTk2NDMyMDB9';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Auth Service Wrappers
export const supabaseAuthService = {
  async getSessionUser() {
    const { data: { session } } = await supabase.auth.getSession();
    return session?.user || {
      id: 'op-04',
      email: 'operator.vikram@agriswarm.in',
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

// Realtime Subscriptions Wrapper
export const subscribeToRealtimeTelemetry = (
  onOperationUpdate: (op: Partial<DroneOperation>) => void,
  onFindingUpdate: (finding: Partial<CropFinding>) => void
) => {
  const channel = supabase
    .channel('agriswarm-operations-realtime')
    .on(
      'postgres_changes',
      { event: 'UPDATE', schema: 'public', table: 'operations' },
      (payload) => {
        onOperationUpdate(payload.new as Partial<DroneOperation>);
      }
    )
    .on(
      'postgres_changes',
      { event: 'INSERT', schema: 'public', table: 'findings' },
      (payload) => {
        onFindingUpdate(payload.new as Partial<CropFinding>);
      }
    )
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
};

// Supabase Storage Bucket Service for PDF Reports & Field Imagery
export const supabaseStorageService = {
  async uploadReportPdf(reportId: string, pdfBlob: Blob) {
    const filePath = `reports/${reportId}.pdf`;
    const { data, error } = await supabase.storage
      .from('agriswarm-reports')
      .upload(filePath, pdfBlob, { upsert: true });

    if (error) {
      console.warn('Supabase storage fallback (offline mode):', error.message);
      return `https://agriswarm-storage.local/reports/${reportId}.pdf`;
    }
    return data.path;
  },

  async getPublicUrl(path: string) {
    const { data } = supabase.storage.from('agriswarm-reports').getPublicUrl(path);
    return data.publicUrl;
  }
};
