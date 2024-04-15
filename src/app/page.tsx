'use client';

import StepOne, { StepOneParams } from "@/components/step-1";
import { Item } from "@/models/item.models";
import { useState, useEffect } from "react";

export default function Home() {

  const [currentStep, setCurrentStep] = useState(1);

  const [items, setItems] = useState<Item[]>([]);

  useEffect(() => {
    setCurrentStep(1);
  }, [currentStep]);

  const StepOneParams: StepOneParams = {
    items,
    setItems,
  };

  return (
    <main className="max-w-[1100px] min-w-[50vw]  w-fit h-screen m-auto py-10">
      <h1 className="text-center text-fourth">Let's Split the Bill</h1>

      <section className="my-10">
        <div>
          <ul className="w-full steps">
            <li className={`step ${currentStep >= 1 && 'step-primary'}`}>Add Items</li>
            <li className={`step ${currentStep >= 2 && 'step-primary'}`}>Add People</li>
            <li className={`step ${currentStep >= 3 && 'step-primary'}`}>Set the Person</li>
            <li className={`step ${currentStep >= 4 && 'step-primary'}`}>Split</li>
          </ul>
        </div>


        <div className="py-20">
          <StepOne params={ StepOneParams } />
        </div>
      </section>
    </main>
  );
}
