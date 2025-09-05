import { updateSession } from '@/utils/supabase/middleware';
import {createPartFromUri, GenerateContentResponse, GoogleGenAI} from '@google/genai';
import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest): Promise<NextResponse> {
  // allow all types of users for now.
  // try {
  //   const user = await updateSession(request);
  //   if (!user) {
  //     throw new Error('Unauthorized');
  //   }
  // } catch (error) {
  //   return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  // }

  const formData = await request.formData();
  const uploadedImage = formData.get('image') as Blob;

  const ai = new GoogleGenAI({apiKey: process.env.GEMINI_API_KEY});

  const myfile = await ai.files.upload({
    file: uploadedImage as Blob,
  });
  const response: GenerateContentResponse = await ai.models.generateContent({
    model: process.env.GEMINI_MODEL || 'gemini-2.0-flash-001',
    contents: [
      createPartFromUri(myfile.uri as string, myfile.mimeType as string),
      '\n\n',
      process.env.SCAN_PROMPT || 'Please extract the data from the image and return it in JSON format.',
    ]
  });
  const items = formatToJson(response.candidates?.[0].content?.parts?.[0].text || '');
  return NextResponse.json(items);
}

function formatToJson(text?: string): JSON {
  return JSON.parse(text?.replace(/```json/g, '').replace(/```/g, '') || '{}');
}